# ==============================================================================
# VPC MODULE: NETWORK INFRASTRUCTURE BLUEPRINT
# ==============================================================================
# In simple terms: This file builds our private "fenced neighborhood" inside AWS.
# Inside this neighborhood, we have:
#   - Public subnets: The front gate/storefront accessible from the internet.
#   - Private subnets: Secure backyard rooms where our apps and databases run safely.
#   - Gateways & Roads: Allowing safe traffic to flow in and out.
# ==============================================================================

# ------------------------------------------------------------------------------
# STEP 1: Discover available AWS Data Centers (Availability Zones)
# AWS has physical data centers in every region (e.g., us-east-1a, us-east-1b).
# We spread our servers across at least 2 data centers so if one loses power,
# our app stays online without interruption.
# ------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------------------
# STEP 2: Create the Virtual Private Cloud (VPC)
# Think of this as buying a piece of land in AWS surrounded by a secure fence.
# ------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # The total pool of IP addresses for our network
  enable_dns_hostnames = true         # Give human-friendly computer names to our servers
  enable_dns_support   = true         # Enable AWS internal phonebook (DNS)

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-vpc"
      Environment                                 = var.environment
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}

# ------------------------------------------------------------------------------
# STEP 3: Create the Internet Gateway (The Front Door)
# This connects our private cloud network directly to the public internet.
# Without this, no user in the world could visit our website.
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-igw"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# STEP 4: Public Subnets (Storefront / Reception Area)
# We create 2 public zones across 2 physical data centers.
# Public load balancers live here to greet incoming web traffic from users.
# ------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Give public IP addresses to load balancers

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-public-${data.aws_availability_zones.available.names[count.index]}"
      Environment                                 = var.environment
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                    = "1" # Tells AWS: "Put public web load balancers here"
    }
  )
}

# ------------------------------------------------------------------------------
# STEP 5: Private Subnets (Secure Backyard / Safe Vaults)
# We create 2 private zones across 2 physical data centers.
# Our backend application servers and databases live here.
# Hackers on the internet CANNOT directly touch these servers!
# ------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-private-${data.aws_availability_zones.available.names[count.index]}"
      Environment                                 = var.environment
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"           = "1" # Tells AWS: "Put private internal services here"
    }
  )
}

# ------------------------------------------------------------------------------
# STEP 6: Elastic Public IP address for the NAT Gateway
# A dedicated permanent public phone number (IP) reserved for our outgoing gateway.
# ------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count      = var.single_nat_gateway ? 1 : 2
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-nat-eip-${count.index + 1}"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# STEP 7: NAT Gateway (One-Way Security Exit Door)
# Our private servers need to download software updates from the internet,
# but we do NOT want internet users connecting directly into our private servers.
# The NAT Gateway acts like a one-way mirror: inside servers can look out,
# but outsiders cannot look in.
# ------------------------------------------------------------------------------
resource "aws_nat_gateway" "nat" {
  count         = var.single_nat_gateway ? 1 : 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-nat-gw-${count.index + 1}"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.gw]
}

# ------------------------------------------------------------------------------
# STEP 8: Public Route Table (Traffic Signpost for Public Area)
# Directs all public web traffic to flow out through the Internet Gateway.
# ------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                # All internet-bound traffic
    gateway_id = aws_internet_gateway.gw.id # Send out through the Front Door
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-public-rt"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# STEP 9: Private Route Table (Traffic Signpost for Private Area)
# Directs private servers to route outbound internet requests through the NAT Gateway.
# ------------------------------------------------------------------------------
resource "aws_route_table" "private" {
  count  = var.single_nat_gateway ? 1 : 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id # Send through One-Way Exit Door
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-private-rt-${count.index + 1}"
      Environment = var.environment
    }
  )
}

# ------------------------------------------------------------------------------
# STEP 10: Connect Subnets to their respective Route Tables
# Telling each area which traffic map to follow.
# ------------------------------------------------------------------------------

# Connect Public Subnets to Public Route Table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Connect Private Subnets to Private Route Table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

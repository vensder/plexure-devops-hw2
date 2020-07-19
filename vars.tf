variable "aws_region" {
  default = "us-east-1"
  /// default = "us-east-2"
  /// default = "us-west-2"
  /// default = "eu-central-1"
  /// default = "eu-west-1" /// too expensive
  /// default = "eu-west-2"
  /// default = "eu-west-3"
  /// default = "eu-north-1"
  /// default = "ca-central-1"
  /// default = "ap-southeast-1"
}

# Ubuntu 18.04 LTS images for different regions:
# amd64, hvm:ebs-ssd, Release: 20200716
# https://cloud-images.ubuntu.com/locator/ec2/
variable "ami" {
  type = map(string) // map(string)
  default = {
    af-south-1     = "ami-094a14422d6cac4f2"
    ap-east-1      = "ami-6de0a01c"
    ap-northeast-1 = "ami-097b5c97a02fdf8f0"
    ap-south-1     = "ami-0e719c023b41dc9f5"
    ap-southeast-1 = "ami-0332756e63b11ea59"
    ca-central-1   = "ami-0699b674a53619db0"
    eu-central-1   = "ami-0d6be5935e0e03181"
    eu-north-1     = "ami-0a7442cccc7d9f0f4"
    eu-south-1     = "ami-0cf657057dfc3888d"
    eu-west-1      = "ami-044ad7103c24bceb3"
    me-south-1     = "ami-04793d4cecaf985fa"
    sa-east-1      = "ami-0d00bb41f06bac65f"
    us-east-1      = "ami-03a2cbdcd9e7d1955"
    us-west-1      = "ami-0428a9c8a1e781dc7"
    cn-north-1     = "ami-0071f6f4df15863cc"
    cn-northwest-1 = "ami-0a22b8776bb32836b"
    us-gov-west-1  = "ami-a23609c3"
    us-gov-east-1  = "ami-776d8206"
    ap-northeast-2 = "ami-0395bf7bf73a9d548"
    ap-southeast-2 = "ami-0c4b69821ea7e3d79"
    eu-west-2      = "ami-06716332fa078b154"
    us-east-2      = "ami-0f4ee0f926e9f568d"
    us-west-2      = "ami-0bea499d92a37a022"
    ap-northeast-3 = "ami-0d0c1ac5131bd8df4"
    eu-west-3      = "ami-0fd53b4cff2b7e694"
  }
}


# Engineering Troubleshooting

This document records significant technical issues encountered during the project and the evidence-based troubleshooting used to identify and resolve them.

## RDS Connectivity and DNS Resolution

### Issue

The private Amazon RDS MySQL instance was deployed, but its AWS-provided RDS endpoint returned `NXDOMAIN` when queried from the EC2 instance.

This prevented the database from being reached using its normal DNS endpoint.

### Investigation

The following areas were investigated:

- VPC DNS support was confirmed as enabled.
- VPC DNS hostnames were confirmed as enabled.
- The VPC DHCP option set was checked for AmazonProvidedDNS.
- The EC2 instance successfully resolved normal internet DNS names.
- The RDS endpoint was tested directly and continued to return `NXDOMAIN`.
- The RDS instance was rebuilt during troubleshooting, but the DNS issue persisted.

At this stage, it was necessary to determine whether the problem affected the underlying EC2-to-RDS network path or specifically the DNS endpoint.

### Network Isolation Test

The private IP address associated with the RDS network interface was identified.

Connectivity from EC2 to this private IP on MySQL TCP port `3306` was tested directly.

The test succeeded.

A MySQL client was then used to connect directly from EC2 to the RDS private IP. The connection succeeded, and:

`SHOW DATABASES;`

returned the expected databases, including `projectdb`.

This demonstrated that the underlying VPC connectivity, security groups, RDS instance and database authentication were functioning.

### Root Cause and Resolution

Further review of the RDS network configuration identified that the database subnet setup was incomplete because only one database subnet had been configured.

Amazon RDS requires a DB subnet group containing subnets in at least two Availability Zones.

A second database subnet was added in a separate Availability Zone, and the RDS DB subnet group was updated to use both subnets.

After correcting the subnet configuration, the RDS endpoint resolved correctly and the database could be accessed using the intended DNS endpoint rather than the private-IP

troubleshooting workaround.

### Final Architecture

The resolved design uses:

- Two database subnets across separate Availability Zones.
- An RDS DB subnet group containing both database subnets.
- A private RDS MySQL instance.
- An RDS security group allowing MySQL TCP `3306` only from the EC2 security group.
- DNS-based RDS endpoint connectivity for normal database access.

### Engineering Lesson

The troubleshooting process demonstrated the importance of isolating individual infrastructure layers rather than repeatedly changing resources without evidence.

Testing the RDS private IP independently of DNS proved that the core network and database path was functional. Reviewing the architecture against the RDS subnet requirements then exposed the missing subnet configuration and allowed the underlying issue to be corrected rather than leaving the private-IP connection as a workaround.

module "vpc_test"{
    #source="../vpc_module"
    source="git::https://github.com/Soumyakusuma/VPC_Module.git?ref=main"
    environment=var.environment
    project=var.project
    pub_cidr=var.pub_cidr
    private_cidr=var.private_cidr
    database_cidr=var.database_cidr
    

}
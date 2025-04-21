workspace extends ./eosc-landscape.dsl {
    
    !impliedRelationships true

    name "SIESTA"
    description "SIESTA architecture"

    model {
        !ref eosc_user {
            description "Scientists willing to analyze sensitive data in the EOSC."
        }
        
        properties {
            "structurizr.groupSeparator" "/"
        }

        siesta = group "SIESTA Trusted Environment for research" {
        
            
            siesta_compute = softwareSystem "SIESTA Secure Compute" "Allows large-scale analysis and processing of sensitive data" {

                access = group "Access" {
                    remote_desktop = container "Remote desktop" "Remote desktop with limited capabilities" "Cendio Thinlinc"
                    api = container "Compute API" "Allows execution of specific tasks, using trusted analysis code" 
                    jeg = container "Interactive analytics" "Allows data scientists to analyze data" "Jupyter Enterprise Gateway Server" "dashboard"
                    usr_interface = container "User interface" "Enables easy interaction with the platform" "Dashboard/CLI"
                }

                external_systems = group "External Systems" {
                    attestation_svc = container "Attestation Service" "" "Coco Trustee"
                    auth_svc = container "AAI" "Authentication and Authorization" "MyAccessID"
                    private_registry = container "Private Registry" "" "Harbor" "storage"
                    secure_repo = container "Code repository" "Stores trusted analysis code" "GitLab" "repository"
                    secrets_mng = container "Secrets manager" "" "Vault"
                    secure_mirror = container "Software mirror" "Allows to install whitelists analytics packages" "" "storage"
                }

                

                compute = group "Compute - K8s cluster" {

                    operator = container "CoCo Operator" "Provides software needed for confidential computing" ""
                    snapshotter = container "Snapshotter" "Manages container storage and downloads images" "Nydus snapshotter"
                    #coco_cloud_enabler = container "CoCo in cloud enabler" "Enables the use of CoCo on the cloud without baremetal" "Cloud API Adaptor"
                    policy_agent = container "Open Policy Agent" "Enforces defined policies" "OPA"
                    compute_env = container "Compute environment", "K8s cluster"
                }
                    
            }
            
            }
            siesta_storage = softwareSystem "SIESTA Secure Storage" "Allows storage of large-scale data in a secure way" {
                anonymization = container "Assisted anonymization tool" "Helps users to anonymize their data using different privacy models (differential privacy k-anonymity, l-diversity, etc.)" "" "dashboard"
                ingestion = container "Data ingestion system" "Allows to fetch data from external sources" "Kafka"
                                
                encrypted_storage = container "Encrypted storage" "Stores data encrypted" "" "storage"
                                                
                data_egress = container "Egress service" "Allows to check that data can be handled accordingly, performing disclosure control, etc." "" "dashboard"
                
                output_data = container "Output data" "Non encrypted storage, providing output data" "" "storage"
            }
            
            reviewer = person "Code reviewer"

            auditor = person "Auditor"

            siesta_audit = softwareSystem "SIESTA audit system" "Allow to tamper-proof trace actions in the compute and storage system" {
                auth = container "Identity" "Provides AuthN/Z to the SIESTA platform" "OpenID Connect"
            }
        

        workflow = softwareSystem "External workflow system" "Executes analytics workflows" "external"

        data_org = group "Data provider" {
            data_owner = person "Data right holder"
            sensitive_data = softwareSystem "Sensitive Data" "" "storage,external"
        }
        external_data = softwareSystem "Non-sensitive data" "" "storage,external"

        # System interaction
        eosc_user -> siesta_compute "Uses"
        sensitive_data -> siesta_storage "Is available in"
        external_data -> siesta_storage "Is available in"
        data_owner -> siesta_storage "Makes data available in"

        siesta_compute -> siesta_storage "Reads data to/from"
        workflow -> siesta_compute "Executes tasks on"

        siesta_storage -> eosc_repo "Can publish data in"
        siesta_compute -> portal "Is registered in"
        /* siesta_storage -> portal "Is registered in" */
        siesta_compute -> aai "Is integrated with"
        siesta_storage -> aai "Is integrated with"
        siesta_compute -> siesta_audit "Registers transactions on"
        siesta_storage -> siesta_audit "Registers transactions on"

        reviewer -> siesta_compute "Ensures code is trusted"
        auditor -> siesta_audit "Audits correct data usage"

        # Data
        sensitive_data -> anonymization "is anonymized" 
        /* anonymization -> data_egress */
        anonymization -> ingestion "sends anonymized data to"
        ingestion -> encrypted_storage "writes anonymized data to"
        external_data -> ingestion "writes data to"
        data_egress -> encrypted_storage "Reads data from"
        data_egress -> output_data "Stages data in"
        output_data -> eosc_repo "Anonymized data can be published in"

        /* jeg -> siesta_audit "Log actions" */
        /* remote_desktop -> siesta_audit "Log actions" */
        /* data_egress -> siesta_audit "Log data transaction" */
        /* output_data -> siesta_audit "Log data transaction" */
        /* compute_env -> siesta_audit "Log compute transaction" */
        /* ingestion -> siesta_audit "Log data transaction" */

        #Data right holder
        data_owner ->  usr_interface "Access the platform via"

        # user actions
        eosc_user -> usr_interface "Access the platform via"
        usr_interface ->  api "Communicates with"
        eosc_user -> jeg "Uses"
        usr_interface -> remote_desktop "Uses (highly sensitive data)"
        remote_desktop -> jeg "Allows access to"
        data_owner -> data_egress "Checks data can be exported"
        data_owner -> anonymization "Anonymizes data using"
        eosc_user -> data_egress "Requests output data"
        eosc_user -> output_data "Reads data from"

        reviewer -> secure_repo "Reviews code in"

        # auth
        /* auth -> aai "Is integrated with" */
        /* eosc_user -> auth "Authenticates with" */
        /* data_owner -> auth "Authenticates with" */
        /* remote_desktop -> auth "Authenticates with" */
        /* jeg -> auth "Authenticates with" */
        /* data_egress -> auth "Authenticates with" */
        /* ingestion -> auth "Authenticates with" */
        usr_interface -> auth_svc "Is integrated with"
                
        # Compute
        jeg -> compute_env "Creates compute tasks"
        compute_env -> encrypted_storage "Reads/writes from"
        compute_env -> secure_mirror "Installs software from"
        api -> compute_env "Executes tasks on"
        api -> secure_repo "Exposes functionality from"
        compute_env -> secure_repo "Reads code from"
        compute_env -> secrets_mng "Reads/writes from"
        compute_env -> private_registry "Downloads images from" 
        attestation_svc ->  compute_env "Attest trustworthiness of"
        compute_env -> snapshotter "Download container images using"
        policy_agent ->  compute_env "Enforces policies"
        operator ->  compute_env "Installs software for confidential computing"

        workflow -> api "Request task execution"

    }

    views {
        theme Default
        
        systemLandscape {
            include *
        }

        container siesta_compute {
            include *
        }
        container siesta_storage {
            include *
        }
        container siesta_audit {
            include *
        }
         
        styles {
            element "Person" {
                background #819595
            }
            
            element "Container" {
                background #fdb5db
                color #000000
                /* shape RoundedBox */
            }

            element "Software System" {
                background #fb7ec1
                color #000000
            }
            element "storage" {
                shape Cylinder
            }
        }

}
}
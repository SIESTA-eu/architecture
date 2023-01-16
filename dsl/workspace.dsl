workspace extends ./eosc-landscape.dsl {
    
#    !impliedRelationships false

    name "SIESTA"
    description "SIESTA architecture"

    model {
        !ref eosc_user {
            description "Scientists willing to analyze sensitive data in the EOSC."
        }

        siesta = enterprise "SIESTA Trusted Environment for research" {
            siesta_platform = softwareSystem "SIESTA Secure Compute" "Allows large-scale analysis and processing of sensitive data" {
                storage = group "Storage" {  
                    anonymization = container "Assisted anonymization tool" "Helps users to anonymize their data using different privacy models (differential privacy k-anonymity, l-diversity, etc.)" "" "dashboard"
                    ingestion = container "Data ingestion system" "Allows to fetch data from external sources" "Kafka"

                    encrypted_storage = container "Encrypted storage" "Stores data encrypted" "" "storage"
                    
                    data_egress = container "Egress service" "Allows to check that data can be handled accordingly, performing disclosure control, etc." "" "dashboard"

                    output_data = container "Output data" "Non ecrypted storage, providing output data" "" "storage"
                }

                access = group "Access" {
                    auth = container "Identity" "Provides AuthN/Z to the SIESTA platform" "OpenID Connect"
                    remote_desktop = container "Remote desktop" "Remote desktop with limited capabilities" "Cendio Thinlink"

                    jeg = container "Interactive analytics" "Allows data scientists to analyze data" "Jupyter Enterprise Gateway Server" "dashboard"
                }

                compute = group "Compute" {

                    compute_env = container "Compute environment"
                    secure_mirror = container "Software mirror" "Allows to install whiteliste analytics packages" "" "storage"
                }
                    
            }

            siesta_audit = softwareSystem "SIESTA audit system" "Allow to tamper-proof trace actions in the compute and storage system" {
            }
        }

        data_org = group "Data provider" {
            data_owner = person "Data owner"
            sensitive_data = softwareSystem "Sensitive Data" "" "storage
        }
        external_data = softwareSystem "Non-sensitive data" "" "storage"

        # System interaction
        eosc_user -> siesta_platform "Uses"
        sensitive_data -> siesta_platform "Is available in"
        external_data -> siesta_platform "Is available in"
        data_owner -> anonymization "Anonymizes data using"
        siesta_platform -> eosc_repo "Can publish data in"
        siesta_platform -> portal "Is registered in"
        siesta_platform -> aai "Is integrated with"
        siesta_platform -> siesta_audit "Registers actions on"

        # Data
        sensitive_data -> anonymization "is anonimized" 
        anonymization -> eosc_repo "can be published in"
        anonymization -> ingestion "sends anonymized data to"
        ingestion -> encrypted_storage "writes anonymized data to"
        external_data -> ingestion "writes data to"
        
        data_egress -> encrypted_storage "Reads data from"
        data_egress -> output_data "Stages data in"
        output_data -> eosc_repo "Can be published in"

        /* jeg -> siesta_audit "Log actions" */
        /* remote_desktop -> siesta_audit "Log actions" */
        /* data_egress -> siesta_audit "Log data transaction" */
        /* output_data -> siesta_audit "Log data transaction" */
        /* compute_env -> siesta_audit "Log compute transaction" */
        /* ingestion -> siesta_audit "Log data transaction" */

        # user actions
        eosc_user -> remote_desktop "Uses (highly sensitive data)"
        eosc_user -> jeg "Uses"
        remote_desktop -> jeg "Allows access to"
        data_owner -> data_egress "Checks data can be exported"
        eosc_user -> data_egress "Requests output data"
        eosc_user -> output_data "Reads data from"

        # auth
        auth -> aai "Is integrated with"
        eosc_user -> auth "Authenticates with"
        data_owner -> auth "Authenticates with"
        /* remote_desktop -> auth "Authenticates with" */
        /* jeg -> auth "Authenticaes with" */
        /* data_egress -> auth "Authenticates with" */
        /* ingestion -> auth "Authenticates with" */

        
        # Compute
        jeg -> compute_env "Creates compute tasks"
        compute_env -> encrypted_storage "Reads/writes from"
        compute_env -> secure_mirror "Installs software from"

    }

    views {
        theme Default
        
        systemLandscape {
            include *
        }

        container siesta_platform {
            include *
        }
        
        styles {
            element "storage" {
                shape Cylinder
            }
        }

}

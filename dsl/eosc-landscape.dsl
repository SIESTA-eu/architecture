workspace eosc "EOSC architecture" {
    
    model {

        eosc_user = person "EOSC User" "An EU researcher willing to exploit EOSC resources and services."

        eosc = group EOSC {
            aai = softwareSystem "EOSC AAI" "Provides Authentication, Authorization and Identity management for EOSC users." "external"
            portal = softwareSystem "EOSC Portal" "Provides access to EOSC resources and services for users." "external"

            eosc_repo = softwareSystem "EOSC Repositorty" "EOSC repository, compliant with EOSC Interoperability Framework." "repository,external"
        }

        aai -> portal "Provides authentication for"

        eosc_user -> portal "Browse EOSC resources, create order for new services"
    }

    views {
        theme Default
        
        systemLandscape eosc {
            include *
            autoLayout lr
        }

        styles {
            element "dashboard" {
                shape WebBrowser
            }       

            element "repository" {
                shape Folder
            }

            element "database" {
                shape Cylinder
            }

            element "external" {
                background lightgrey
            }
        }
    }
}

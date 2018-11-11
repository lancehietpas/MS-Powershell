Import-Module ActiveDirectory
 Set-ADUser -Identity jdoe -Add @{proxyAddresses="smtp:johndoe@ymcafoxcities.org"}

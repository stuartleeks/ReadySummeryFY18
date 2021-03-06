#!/bin/bash

# expects the following env vars to be set: AZDNS_RESOURCE_GROUP

DOMAIN=""
SUBDOMAIN=""

function show_usage(){
    echo "set-a-record"
    echo
    echo -e "\t--domain\tSpecify the domain name"
    echo -e "\t--subdomain\tSpecify the subdomain"
}

while [[ $# -gt 0 ]]
do
    case "$1" in 
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --subdomain)
            SUBDOMAIN="$2"
            shift 2
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
done

if [ -z $DOMAIN ]; then
    echo "domain not specified"
    echo
    show_usage
    exit 1
fi

if [ -z $SUBDOMAIN ]; then
    echo "subdomain not specified"
    echo
    show_usage
    exit 1
fi

current_ip_address=$(az network dns record-set  a show --resource-group $AZDNS_RESOURCE_GROUP --zone-name $DOMAIN --name $SUBDOMAIN --query "arecords[0].ipv4Address" --output tsv)

if [[ $current_ip_address == "" ]]; then
    # no record yet - nothing to do
    echo "not found"
else
    # existing record - delete it
    echo "deleting $SUBDOMAIN.$DOMAIN..."
    az network dns record-set a delete --resource-group $AZDNS_RESOURCE_GROUP --zone-name $DOMAIN --name $SUBDOMAIN --yes
fi
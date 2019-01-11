# Quickly create a test environment with 1-n Azure VMs

### Usage
- Open the script and check/modify the values to your convenience, most important the subscription name
- Execute the script and connect with your Azure account
- Two path:
    - If the Resource Group doesn´t exist, the Script will ask you how many VMs you want to have deployed and will deploy those async
    - If the Resource Group does exist you have to option to delete your test environment or recreate a new one (deleting the old one)

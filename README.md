For "Template Module Windows network by JTakyLR.xml"
There is a flaw in the official template.
If used Win32_networkadapter, and if the server has several network interfaces, we get an error.
Error - "LLD network interfaces: "Cannot create item: item with same key already exists""
Template Module Windows network by zabbix agent
--- Replace win32_networkadapter on MSFT_NetAdapter

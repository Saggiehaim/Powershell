# VMware Snapshot Report

Snapshots are great, but they can be your worst enemy if you don’t use them correctly. The “issue” with snapshots is that they save your delta’s. This means that every change happening on the VM is “recorded” on the snapshot, “another change to revert”. as the time pass, the snapshot will grow and grow with the limit set to your free space on HDD’s.

You can learn how to use the script in my blog post: https://www.saggiehaim.net/powershell/create-vmware-snapshots-report/

All feedback welcomed!

contact me at contact@saggiehaim.net
https://www.saggiehaim.net/

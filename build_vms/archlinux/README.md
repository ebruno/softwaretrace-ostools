|Mount point on the installed system	| Partition  |	Partition type |	Suggested size|
|:------------------|:-----------------|:-------------|:-------------|
|/boot1 | /dev/efi_system_partition	| EFI system partition	1 GiB|
|[SWAP] | /dev/swap_partition         |		Linux swap	At least 4 GiB|
|/		| /dev/root_partition	| Linux x86-64 root (/) |	Remainder of the device. At least 23–32 GiB.|

Set partion 1 bootable.

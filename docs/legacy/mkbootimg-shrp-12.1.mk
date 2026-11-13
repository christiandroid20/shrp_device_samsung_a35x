# Legacy SHRP 12.1 mkbootimg override.
# Not used by AERA 16.0. Retained only for historical reference.
#
# The AERA build must use its own standard recovery image packaging rules.
#
# Original source from the pre-AERA A35X tree:
#
# $(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel) $(RECOVERYIMAGE_EXTRA_DEPS)
#	@echo "----- Making recovery image ------"
#	$(hide) $(MKBOOTIMG) \
#		--kernel $(recovery_kernel) \
#		--ramdisk $(recovery_ramdisk) \
#		$(INTERNAL_MKBOOTIMG_VERSION_ARGS) \
#		$(BOARD_MKBOOTIMG_ARGS) \
#		--recovery_dtbo $(BOARD_PREBUILT_DTBOIMAGE) \
#		--output $@
#	$(hide) echo -n "SEANDROIDENFORCE" >> $@
#	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)

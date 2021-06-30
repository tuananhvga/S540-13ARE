ConservationValues=(Disabled Enabled)
PerformanceValues=("Intelligent Cooling" "Extreme Performance" "Battery Saving")
if [ $# == 0 ]
then
    # Conservation Mode inspect
    ConservationMode=$(cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode)
    echo "Conservation mode :" ${ConservationValues[$ConservationMode]}

    echo '\_SB.PCI0.LPC0.EC0.FCMO' > /proc/acpi/call

    # Performance Mode inspect
    PerformanceMode=$(cat /proc/acpi/call | cut -d '' -f1)
    echo "Performance Mode:" ${PerformanceValues[${PerformanceMode:-1}]}
    exit 0
fi
if [ $# == 1 ] && [ "$1" == "change" ]
then
    # Change mode
    echo "Choose which to change:"
    echo "1) Conservation Mode"
    echo "2) Performance Mode"
    read Choice
    case "$Choice" in
        1)
            echo "0 : Disabled"
            echo "1 : Enabled"
            read Choice
            if [ "$Choice" -gt 1 ] || [ "$Choice" -lt 0 ]
            then
                echo "Invalid choice"
            else
                echo ${Choice} | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
                echo ${ConservationValues[${Choice}]}
            fi
            ;;
        2)
            for ((i = 0;i <= 2;i++))
            do
                echo ${i}")" ${PerformanceValues[${i}]}
            done
            read Choice
            if [ "$Choice" -gt 2 ] || [ "$Choice" -lt 0 ]
            then
                echo "Invalid choice"
            else
                case "$Choice" in
                    0) echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' | sudo tee /proc/acpi/call;;
                    1) echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' | sudo tee /proc/acpi/call;;
                    2) echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' | sudo tee /proc/acpi/call;;
                esac
                echo "Set to" ${PerformanceValues[${Choice}]}
            fi
            ;;
        *)
            echo "Invalid choice";;
    esac
else
    # Print instruction
    echo "Invalid argument"
    echo "mode.sh [change]"
    echo "Use change argument to modify modes"
fi

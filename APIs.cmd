echo "$(date) Starting API estimation for AUS"
gawk -vcountry="AUS" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/AUS/RI_AUS.txt > ./Country_Results/AUS/APIs_IBES_std_output_AUS.txt
echo "$(date) Starting API estimation for CAN"
gawk -vcountry="CAN" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/CAN/RI_CAN.txt > ./Country_Results/CAN/APIs_IBES_std_output_CAN.txt
echo "$(date) Starting API estimation for CHN"
gawk -vcountry="CHN" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/CHN/RI_CHN.txt > ./Country_Results/CHN/APIs_IBES_std_output_CHN.txt
echo "$(date) Starting API estimation for DEU"
gawk -vcountry="DEU" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/DEU/RI_DEU.txt > ./Country_Results/DEU/APIs_IBES_std_output_DEU.txt
echo "$(date) Starting API estimation for FRA"
gawk -vcountry="FRA" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/FRA/RI_FRA.txt > ./Country_Results/FRA/APIs_IBES_std_output_FRA.txt
echo "$(date) Starting API estimation for GBR"
gawk -vcountry="GBR" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/GBR/RI_GBR.txt > ./Country_Results/GBR/APIs_IBES_std_output_GBR.txt
echo "$(date) Starting API estimation for HKG"
gawk -vcountry="HKG" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/HKG/RI_HKG.txt > ./Country_Results/HKG/APIs_IBES_std_output_HKG.txt
echo "$(date) Starting API estimation for IDN"
gawk -vcountry="IDN" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/IDN/RI_IDN.txt > ./Country_Results/IDN/APIs_IBES_std_output_IDN.txt
echo "$(date) Starting API estimation for JPN"
gawk -vcountry="JPN" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/JPN/RI_JPN.txt > ./Country_Results/JPN/APIs_IBES_std_output_JPN.txt
echo "$(date) Starting API estimation for KOR"
gawk -vcountry="KOR" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/KOR/RI_KOR.txt > ./Country_Results/KOR/APIs_IBES_std_output_KOR.txt
echo "$(date) Starting API estimation for MYS"
gawk -vcountry="MYS" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/MYS/RI_MYS.txt > ./Country_Results/MYS/APIs_IBES_std_output_MYS.txt
echo "$(date) Starting API estimation for NZL"
gawk -vcountry="NZL" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/NZL/RI_NZL.txt > ./Country_Results/NZL/APIs_IBES_std_output_NZL.txt
echo "$(date) Starting API estimation for PHL"
gawk -vcountry="PHL" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/PHL/RI_PHL.txt > ./Country_Results/PHL/APIs_IBES_std_output_PHL.txt
echo "$(date) Starting API estimation for SGP"
gawk -vcountry="SGP" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/SGP/RI_SGP.txt > ./Country_Results/SGP/APIs_IBES_std_output_SGP.txt
echo "$(date) Starting API estimation for THA"
gawk -vcountry="THA" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/THA/RI_THA.txt > ./Country_Results/THA/APIs_IBES_std_output_THA.txt
echo "$(date) Starting API estimation for TWN"
gawk -vcountry="TWN" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk ./Country_Data/TWN/RI_TWN.txt > ./Country_Results/TWN/APIs_IBES_std_output_TWN.txt

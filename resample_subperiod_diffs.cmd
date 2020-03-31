echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for AUS"
gawk -v niter=1000 -v country="AUS" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/AUS/API_sub_periods_overlap=YES_censor=NO_AUS.txt > ./Country_Results/AUS/resample_subperiod_APIs_IBES_output_AUS.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for CAN"
gawk -v niter=1000 -v country="CAN" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/CAN/API_sub_periods_overlap=YES_censor=NO_CAN.txt > ./Country_Results/CAN/resample_subperiod_APIs_IBES_output_CAN.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for CHN"
gawk -v niter=1000 -v country="CHN" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/CHN/API_sub_periods_overlap=YES_censor=NO_CHN.txt > ./Country_Results/CHN/resample_subperiod_APIs_IBES_output_CHN.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for DEU"
gawk -v niter=1000 -v country="DEU" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/DEU/API_sub_periods_overlap=YES_censor=NO_DEU.txt > ./Country_Results/DEU/resample_subperiod_APIs_IBES_output_DEU.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for FRA"
gawk -v niter=1000 -v country="FRA" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/FRA/API_sub_periods_overlap=YES_censor=NO_FRA.txt > ./Country_Results/FRA/resample_subperiod_APIs_IBES_output_FRA.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for GBR"
gawk -v niter=1000 -v country="GBR" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/GBR/API_sub_periods_overlap=YES_censor=NO_GBR.txt > ./Country_Results/GBR/resample_subperiod_APIs_IBES_output_GBR.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for HKG"
gawk -v niter=1000 -v country="HKG" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/HKG/API_sub_periods_overlap=YES_censor=NO_HKG.txt > ./Country_Results/HKG/resample_subperiod_APIs_IBES_output_HKG.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for IDN"
gawk -v niter=1000 -v country="IDN" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/IDN/API_sub_periods_overlap=YES_censor=NO_IDN.txt > ./Country_Results/IDN/resample_subperiod_APIs_IBES_output_IDN.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for JPN"
gawk -v niter=1000 -v country="JPN" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/JPN/API_sub_periods_overlap=YES_censor=NO_JPN.txt > ./Country_Results/JPN/resample_subperiod_APIs_IBES_output_JPN.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for KOR"
gawk -v niter=1000 -v country="KOR" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/KOR/API_sub_periods_overlap=YES_censor=NO_KOR.txt > ./Country_Results/KOR/resample_subperiod_APIs_IBES_output_KOR.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for MYS"
gawk -v niter=1000 -v country="MYS" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/MYS/API_sub_periods_overlap=YES_censor=NO_MYS.txt > ./Country_Results/MYS/resample_subperiod_APIs_IBES_output_MYS.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for NZL"
gawk -v niter=1000 -v country="NZL" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/NZL/API_sub_periods_overlap=YES_censor=NO_NZL.txt > ./Country_Results/NZL/resample_subperiod_APIs_IBES_output_NZL.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for PHL"
gawk -v niter=1000 -v country="PHL" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/PHL/API_sub_periods_overlap=YES_censor=NO_PHL.txt > ./Country_Results/PHL/resample_subperiod_APIs_IBES_output_PHL.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for SGP"
gawk -v niter=1000 -v country="SGP" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/SGP/API_sub_periods_overlap=YES_censor=NO_SGP.txt > ./Country_Results/SGP/resample_subperiod_APIs_IBES_output_SGP.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for THA"
gawk -v niter=1000 -v country="THA" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/THA/API_sub_periods_overlap=YES_censor=NO_THA.txt > ./Country_Results/THA/resample_subperiod_APIs_IBES_output_THA.txt
echo "$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for TWN"
gawk -v niter=1000 -v country="TWN" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/TWN/API_sub_periods_overlap=YES_censor=NO_TWN.txt > ./Country_Results/TWN/resample_subperiod_APIs_IBES_output_TWN.txt

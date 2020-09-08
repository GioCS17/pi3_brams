###########################################################################################
function verifica_dps () {
### Verificando se os dp´s estao OK ###
existe_dp=1
t=1
tam_dp=199577651
while [ $t -le "$tmax_dp" ]; do
    if ! test -s "${DPS_DIR}/dp${data_arr[$t]}"; then
        echo "Nao foi encontrado o dp: ${DPS_DIR}/dp${data_arr[$t]}"
        existe_dp=0
    else
        tam=$(ls -l ${DPS_DIR}/dp${data_arr[$t]} | awk '{print $5}')
            if [ ${tam} -ne ${tam_dp} ]; then
            echo "dp com tamanho errado ${tam_dp}<>${tam} :" "${DPS_DIR}/dp${data_arr[$t]}"
            existe_dp=0
        fi
    fi
    t=$(expr $t + 1)
done
if [ "$existe_dp" -eq 1 ]; then
    echo "DPs Gerados anteriormente: ${edate}"
fi
}
###########################################################################################
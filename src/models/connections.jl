# Network parameters

#NI_FAST = 0.35
#NI_SLOW = 0.65
#N_INH   = 0.2
#N_EXC   = 0.8

const duarte_types = [0.8, 0.2 * 0.65, 0.2 * 0.35]
const pv_only = [0.8, 0.0, 0.2]
const sst_only = [0.8, 0.2, 0.0]



const duartemorrison2017_soma = ConnectionProbability(
    ρe_s_e = 0.168,
    ρif_e = 0.575,
    ρis_e = 0.244,
    ρe_if = 0.60,
    ρe_s_is = 0.465,
    ρif_if = 0.55,
    ρis_if = 0.24,
    ρif_is = 0.379,
    ρis_is = 0.381,
    μe_e = 0.45,
    μif_e = 1.65,
    μis_e = 0.638,
    μe_if = 5.148,
    μe_is = 4.85,
    μif_if = 2.22,
    μis_if = 1.4,
    μif_is = 1.47,
    μis_is = 0.83,
)
const lkd2014_dend = ConnectionProbability(
    ρe_d_e = 0.2,
    # ρe_s_e  = 0.1,
    μe_e = 10.78,
    ρis_e = 0.2,
    ρif_e = 0.2,
    μif_e = 5.27,
    μis_e = 5.27,
    σif_e = 0.10,
    σis_e = 0.11,
    ρe_if = 0.2,
    ρe_d_is = 0.2,
    μe_if = 15.8,
    μe_is = 15.8,
    ρif_if = 0.2,
    ρis_is = 0.2,
    μif_if = 16.2,
    μis_is = 16.2,
    σif_if = 0.14,
    σis_if = 0.25,
    ρif_is = 0.2,
    ρis_if = 0.2,
    μif_is = 1.47,
    μis_if = 0.83,
    σif_is = 0.10,
    σis_is = 0.2,
)

const lkd2014_dend_upinh = ConnectionProbability(
    ρe_d_e = 0.2,
    # ρe_s_e  = 0.1,
    μe_e = 10.78,
    ρis_e = 0.4,
    ρif_e = 0.4,
    μif_e = 5.27,
    μis_e = 5.27,
    σif_e = 0.10,
    σis_e = 0.11,
    ρe_if = 0.4,
    ρe_d_is = 0.4,
    μe_if = 15.8,
    μe_is = 15.8,
    ρif_if = 0.4,
    ρis_is = 0.4,
    μif_if = 16.2,
    μis_is = 16.2,
    σif_if = 0.14,
    σis_if = 0.25,
    ρif_is = 0.4,
    ρis_if = 0.4,
    μif_is = 1.47,
    μis_if = 0.83,
    σif_is = 0.10,
    σis_is = 0.2,
)

ρ0 = 0.2
const dend_exc_ρ(ρ) = ConnectionProbability(
    ρe_d_e = ρ,
    μe_e = 10.0 * ρ0 / ρ,
    ρis_e = 0.2,
    ρif_e = 0.2,
    μif_e = 5.27,
    μis_e = 5.27,
    σif_e = 0.10,
    σis_e = 0.11,
    ρe_if = 0.2,
    ρe_d_is = 0.2,
    μe_if = 15.8,
    μe_is = 15.8,
    ρif_if = 0.2,
    ρis_is = 0.2,
    μif_if = 16.2,
    μis_is = 16.2,
    σif_if = 0.14,
    σis_if = 0.25,
    ρif_is = 0.2,
    ρis_if = 0.2,
    μif_is = 1.47,
    μis_if = 0.83,
    σif_is = 0.10,
    σis_is = 0.2,
)
const lkd2014_soma = ConnectionProbability(
    ρe_s_e = 0.2,
    ρis_e = 0.2,
    ρif_e = 0.2,
    ρe_if = 0.2,
    μe_e = 2.76,
    μe_if = 48.7,
    μif_e = 1.27,
    ρif_if = 0.2,
    μif_if = 16.2,
)
lkd2014_soma_j(j0) = ConnectionProbability(
    ρe_s_e = 0.2,
    ρis_e = 0.2,
    ρif_e = 0.2,
    ρe_if = 0.2,
    μe_e = j0,
    μe_if = 48.7,
    μif_e = 1.27,
    ρif_if = 0.2,
    μif_if = 16.2,
)
const duartemorrison2017_dend = ConnectionProbability(
    ρe_d_e = 0.168,
    ρif_e = 0.575,
    ρis_e = 0.244,
    ρe_if = 0.60,
    ρe_d_is = 0.465,
    ρif_if = 0.55,
    ρis_if = 0.24,
    ρif_is = 0.379,
    ρis_is = 0.381,
    μe_e = 0.45,
    μif_e = 1.65,
    μis_e = 0.638,
    μe_if = 5.148,
    μe_is = 4.85,
    μif_if = 2.22,
    μis_if = 1.4,
    μif_is = 1.47,
    μis_is = 0.83,
)
const no_connections = ConnectionProbability()

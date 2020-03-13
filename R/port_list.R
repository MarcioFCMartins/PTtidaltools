#' Show list of port ids
#'
#' Returns a data.frame with the port ID's used in get_tides
#' Based on data scrapped on 2020/03/13
#' If port_id is not working, use get_port_ids to generate an updated list
#'
#' 
#' @examples
#' port_list()
#' 
#' @export

port_list <- function(){
    return(
        structure(list(port_id = c(12L, 13L, 15L, 16L, 18L, 19L, 20L, 
21L, 28L, 29L, 43L, 73L, 74L, 112L, 211L, 221L, 231L, 243L, 245L, 
311L, 312L, 335L, 411L, 412L, 413L, 511L, 521L, 611L, 612L, 613L, 
614L, 711L, 712L, 713L, 714L, 715L, 716L, 717L, 718L, 719L, 721L, 
727L, 814L), port_name = structure(1:43, .Label = c("Leixões", 
"Aveiro - Molhe Central", "Cascais", "Lisboa", "Lagos", "Faro - Olhão", 
"Setúbal - Tróia", "Vila Real de Santo António", "Sesimbra", 
"Peniche", "Sines", "Figueira da Foz", "Viana do Castelo", "Funchal", 
"Ponta Delgada", "Angra do Heroísmo", "Horta", "Lajes das Flores", 
"Vila do Porto", "Porto Grande", "Praia", "Palmeira", "Porto do Cacheu", 
"Ilheu do Caió", "Porto de Bubaque", "Baía de Ana Chaves", "Baía de St. António", 
"Soyo", "Luanda", "Lobito", "Namibe", "Maputo", "Inhambane", 
"Beira", "Chinde", "Quelimane", "Pebane", "Angoche", "Ilha de Moçambique", 
"Pemba", "Mocimboa da Praia", "Nacala", "Porto de Macau"), class = "factor")), row.names = c(NA, 
-43L), class = "data.frame")
    )
}

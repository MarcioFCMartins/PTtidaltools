#' Get the latest list of ports id's
#'
#' Queries potential port ID's from the Portuguese National Hydrographic Institute and returns a data.frame with valid ones 
#' @export

# The National Hidrographic Institute homepage link:
homepage <- "https://www.hidrografico.pt"

# The tide information is obtained by selecting a port, a starting date 
# and the number of days to display. This information is then sent in a 
# html request to "json/mare.port.val.php?po="+po+"&dd="+dd+"&nd="+nd
# where po = port ID, dd = date, nd = number of days

# I can replace the information I need in this string and use the 
# html request to get the tide information

# Some trial and error showed that: 
## date should be provided as yyyymmdd
## number of days should be any number
## the Port ID can be determined by querying the port notes (see below) and 
## taking the first line
get_port_ids <- function() {
  available_ports <- data.frame()

  for (port_id in 1:1000) {
    message(port_id)
    link <- paste0(
      "https://hidrografico.pt/get_port_notes_ajax.php?port_id=",
      port_id
    )
    # Get the port notes for that id
    port_notes <- read_html(link) %>%
      html_text()

    # Check if the id is valid. If not, skip this id
    if (grepl("^Avisos para este porto", port_notes)) {
      message(paste("Port", port_id, "is not valid, trying next one."))
      next
    } else {

      # Get name of port
      port_name <- sub("Avisos.*", "", port_notes)

      port <- data.frame(
        "port_id" = port_id,
        "port_name" = port_name
      )

      available_ports <- rbind(available_ports, port)
    }
  }
}

#' @rdname margins
#' @export
margins.default <- 
function(model, 
         data = find_data(model, parent.frame()), 
         at = NULL, 
         type = c("response", "link", "terms"),
         vcov = stats::vcov(model),
         vce = c("none", "delta", "simulation", "bootstrap"),
         iterations = 50L, # if vce == "bootstrap" or "simulation"
         unit_ses = FALSE,
         eps = 1e-7,
         ...) {
    
    # match.arg()
    type <- match.arg(type)
    vce <- match.arg(vce)
    
    # setup data
    data_list <- build_datalist(data, at = at)
    if (is.null(names(data_list))) {
        names(data_list) <- NA_character_
    }
    
    # warn about weights
    warn_for_weights(model)
    
    # calculate marginal effects
    out <- list()
    for (i in seq_along(data_list)) {
        out[[i]] <- build_margins(model = model, 
                                  data = data_list[[i]], 
                                  type = type, 
                                  vcov = vcov, 
                                  vce = vce, 
                                  iterations = iterations, 
                                  unit_ses = unit_ses, 
                                  eps = eps, 
                                  ...)
    }
    
    # return value
    structure(do.call("rbind", out), 
              class = c("margins", "data.frame"), 
              at = if (is.null(at)) at else names(at),
              type = type,
              call = if ("call" %in% names(model)) model[["call"]] else NULL,
              vce = vce, 
              iterations = if (vce == "bootstrap") iterations else NULL)
}

warn_for_weights <- function(model) {
    wghts <- unname(model[["weights"]])
    if (!isTRUE(all.equal(wghts, rep(wghts[1], length(wghts))))) {
        warning("'weights' used in model estimation are currently ignored!")
    }
    NULL
}


# $Id$

predict.BinaryTree <- function(object, ...) {
    conditionalTree@predict(object, ...)
}

predict.RandomForest <- function(object, OOB = FALSE, scale = TRUE, ...) {
    RandomForest@predict(object, OOB = OOB, scale = TRUE, ...)
}

setGeneric("treeresponse", function(object, ...) 
           standardGeneric("treeresponse"))

setMethod("treeresponse", signature = signature(object = "BinaryTree"),
    definition = function(object, newdata = NULL, ...)   
        object@cond_distr_response(newdata = newdata, ...)
)

setMethod("treeresponse", signature = signature(object = "RandomForest"),
    definition = function(object, newdata = NULL, scale = TRUE, ...)   
        object@cond_distr_response(newdata = newdata, scale = TRUE, ...)
)


### weights is an S3 generic
###setGeneric("weights", function(object, ...) standardGeneric("weights"))
###
###setMethod("weights", signature = signature(object = "BinaryTree"),
###    definition = function(object, newdata = NULL, ...)
###        object@prediction_weights(newdata = newdata, ...)
###)
###
###setMethod("weights", signature = signature(object = "RandomForest"),
###    definition = function(object, newdata = NULL, OOB = FALSE, ...)
###        object@prediction_weights(newdata = newdata, OOB = OOB, ...)
###)

weights.BinaryTree <- function(object, newdata = NULL, ...)
    object@prediction_weights(newdata = newdata, ...)

weights.RandomForest <- function(object, newdata = NULL, OOB = FALSE, scale = TRUE, ...)
    object@prediction_weights(newdata = newdata, OOB = OOB, scale = TRUE, ...)

setGeneric("where", function(object, ...) standardGeneric("where"))

setMethod("where", signature = signature(object = "BinaryTree"),
    definition = function(object, newdata = NULL, ...) {
        if(is.null(newdata)) object@where
	    else object@get_where(newdata = newdata, ...)
    }
)

setMethod("where", signature = signature(object = "RandomForest"),
    definition = function(object, newdata = NULL, ...) {
        if(is.null(newdata)) object@where
	    else object@get_where(newdata = newdata, ...)
    }
)


setGeneric("nodes", function(object, where, ...) standardGeneric("nodes"))

setMethod("nodes", signature = signature(object = "BinaryTree", 
                                         where = "integer"),
    definition = function(object, where, ...)
        lapply(where, function(i) .Call(R_get_nodebynum, object@tree, i))
)

setMethod("nodes", signature = signature(object = "BinaryTree", 
                                         where = "numeric"),
    definition = function(object, where, ...)
        nodes(object, as.integer(where))
)

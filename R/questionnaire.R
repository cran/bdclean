#' Create the package default Questionnaire.
#'
#' @return BdQuestionContainer object with default Questions
#'
#' @examples
#'
#' customQuestionnaire <- create_default_questionnaire()
#'
#' @export
create_default_questionnaire <- function() {
    question1 <-
        BdQuestion(
            question = "Do you worry about taxonomical aspect of the data?",
            possible.responses = c("Yes", "No"),
            question.type = "Router",
            router.condition = c("Yes", "Y", "yes", 1, TRUE, "TRUE"),
            question.id = "taxonMain",
            ui.type = "single-checkbox"
        )
    
    question2 <-
        BdQuestion(
            question = "What is the lowest taxonomic level you require in your data?",
            possible.responses = c(
                "Subspecies",
                "Species",
                "Genus",
                "Family",
                "Order",
                "Class"
            ),
            question.type = "Child",
            quality.checks = c("taxo_level"),
            question.id = "taxonLevel",
            ui.type = "select"
        )
    
    question1$add_child_question(c(question2))
    
    question3 <-
        BdQuestion(
            question = "Do you worry about spatial aspect of the data?",
            possible.responses = c("Yes", "No"),
            question.type = "Router",
            router.condition = c("Yes", "Y", "yes", 1, TRUE, "TRUE"),
            quality.checks = c("DC_coordinatesZero"),
            question.id = "spatialMain",
            ui.type = "single-checkbox"
        )
    
    question4 <-
        BdQuestion(
            question = "What is the spatial resolution required for your data? (in meteres)",
            question.type = "Child",
            quality.checks = c("spatial_resolution"),
            question.id = "spatialResolution",
            ui.type = "numericInput"
        )
    
    question4$add_validation_function(function(answer) {
        answer <- suppressWarnings(as.numeric(answer))
        check <- (!is.na(answer) && answer > 0 && answer < 1e+05)
        if (!check) {
            message(
                "Spatial resolution should be a number between 0 to 100 KM. Please give a correct value."
            )
        }
        return(check)
    })
    
    question_sub_01 <-
        BdQuestion(
            question = "Do you worry about precision of coordinates?",
            possible.responses = c("Yes", "No"),
            question.type = "ChildRouter",
            router.condition = c("Yes", "Y", "yes", 1, TRUE, "TRUE"),
            quality.checks = c(
                "DC_coordinatePrecisionMismatch",
                "DC_precisionRangeMismatch",
                "DC_uncertaintyRangeMismatch"
            ),
            question.id = "precisionCoord",
            ui.type = "single-checkbox"
        )
    
    question_sub_02 <-
        BdQuestion(
            question = "Do you worry about countries of occurrences?",
            possible.responses = c("Yes", "No"),
            question.type = "ChildRouter",
            router.condition = c("Yes", "Y", "yes", 1, TRUE, "TRUE"),
            quality.checks = c("DC_countryMismatch", "DC_countryNameUnknown"),
            question.id = "countryCoord",
            ui.type = "single-checkbox"
        )
    
    question_sub_03 <-
        BdQuestion(
            question = "Do you worry about elevation of occurrences?",
            possible.responses = c("Yes", "No"),
            router.condition = c("Yes",
                                 "Y", "yes", 1, TRUE, "TRUE"),
            question.type = "ChildRouter",
            quality.checks = c("DC_depthOutOfRange", "DC_elevationOutOfRange"),
            question.id = "elevationCoord",
            ui.type = "single-checkbox"
        )
    
    question3$add_child_question(c(
        question4,
        question_sub_01,
        question_sub_02,
        question_sub_03
    ))
    
    question5 <-
        BdQuestion(
            question = "Do you worry about temporal aspect of your data?",
            possible.responses = c("Yes", "No"),
            question.type = "Router",
            router.condition = c("Yes", "Y", "yes", 1, TRUE, "TRUE"),
            quality.checks = c(
                "DC_dateNull",
                "DC_dayInvalid",
                "DC_eventDateInFuture",
                "DC_monthInvalid",
                "DC_yearMissing"
            ),
            question.id = "temporalMain",
            ui.type = "single-checkbox"
        )
    
    question6 <-
        BdQuestion(
            question = "What is the range of dates of the observations in this data set? In format (YYYY-mm-dd YYYY-mm-dd)",
            question.type = "Child",
            quality.checks = c("earliest_date"),
            question.id = "temporalEarliest",
            ui.type = "date-range"
        )
    
    question6$add_validation_function(function(answer) {
        dates <- strsplit(answer, " ")[[1]]
        d <- try(as.Date(dates[1]))
        if (class(d) == "try-error" || is.na(d)) {
            message("Invalid Date! Please follow the date format (YYYY-mm-dd)")
            return(FALSE)
        }
        d <- try(as.Date(dates[2]))
        if (class(d) == "try-error" || is.na(d)) {
            message("Invalid Date! Please follow the date format (YYYY-mm-dd)")
            return(FALSE)
        }
        return(TRUE)
    })
    
    question7 <-
        BdQuestion(
            question = "What temporal resolution are you interested in?",
            possible.responses = c("Day", "Month", "Year"),
            question.type = "Child",
            quality.checks = c("temporal_resolution"),
            question.id = "temporalResolution",
            ui.type = "radio"
        )
    
    question_sub_04 <-
        BdQuestion(
            question = "Do you worry about dates other than occured date (published date/identified date)?",
            possible.responses = c("Yes",
                                   "No"),
            question.type = "ChildRouter",
            router.condition = c("Yes", "Y", "yes", 1, TRUE, "TRUE"),
            quality.checks = c(
                "DC_identifiedDateImprobable",
                "DC_modifiedInFuture",
                "DC_namePublishedYearInFuture"
            ),
            question.id = "smallerDates",
            ui.type = "single-checkbox"
        )
    
    question5$add_child_question(c(question6, question7, question_sub_04))
    
    question_sub_05 <-
        BdQuestion(
            question = "Do you worry about other properties of occurrence? (GBIF issues/publisher/occuranceremark, etc)?",
            possible.responses = c("Yes", "No"),
            question.type = "Router",
            router.condition = c("Yes", "Y", "yes", 1, TRUE, "TRUE"),
            quality.checks = c(
                "DC_basisOfRecordBadlyFormed",
                "DC_classUnknown",
                "DC_dataGeneralised",
                "DC_individualcountInvalid",
                "DC_occurrenceIdNotGuid"
            ),
            question.id = "smallerIssues",
            ui.type = "single-checkbox"
        )
    
    all_questions <-
        BdQuestionContainer(
            c(
                question1,
                question2,
                question3,
                question4,
                question_sub_01,
                question_sub_02,
                question_sub_03,
                question5,
                question6,
                question7,
                question_sub_04,
                question_sub_05
            )
        )
    return(all_questions)
}

$(document).ready(function () {
    $(document)
        .on("click", "#update_user_details_button", submitUpdateUserDetailsForm);
});


/**
* DOCU: This function will trigger the submission of update_user_details_form<br>
* Triggered: .on("click", "#update_user_details_button", submitUpdateUserDetailsForm)<br>
* Last Updated Date: September 28, 2022
* @author Adrian
*/
function submitUpdateUserDetailsForm(e){
    e.preventDefault()

    let update_user_details_form = $("#update_user_details_form");

    $.post(update_user_details_form.attr("action"), update_user_details_form.serialize(), function(update_user_details_form_response){
        if(update_user_details_form_response.status){
            /* TODO: Alert for now for faster coding */
            alert("User details saved successfully!");
        }
        else{
            /* TODO: Alert for now for faster coding */
            let { email, name } = update_user_details_form_response.result;

            if(email){
                alert(email);
            }
            if(name){
                alert(name);
            }

            if(update_user_details_form_response.error){
                alert(update_user_details_form_response.error)
            }
        }
    });
}
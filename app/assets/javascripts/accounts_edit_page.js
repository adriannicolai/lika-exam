$(document).ready(function () {
    $(document)
        .on("click", "#update_user_details_button", submitUpdateUserDetailsForm);
});


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

            if(email) {
                alert(email);
            }
            if (name) {
                alert(name);
            }
        }
    });
}
$(document).ready(function () {
    $(document)
        .on("click", "#login_user_button", submitLoginUserForm);
});

/**
* DOCU: This function will trigger the submission of login_user_form<br>
* Triggered: .on("click", "#login_user_button", submitLoginUserForm);<br>
* Last Updated Date: September 28, 2022
* @author Adrian
*/
function submitLoginUserForm(e) {
    e.preventDefault()

    let login_user_form = $("#login_user_form");

    $.post(login_user_form.attr("action"), login_user_form.serialize(), function (login_user_form_response) {
        if (login_user_form_response.status) {
            /* TODO: Alert for now for faster coding
                redirect user to home page
            */
            window.open("/accounts/home_page", "_self");
        }
        else {
            /* TODO: Alert for now for faster coding */
            alert("User not found, Please check your email and/or password");
        }
    });
}
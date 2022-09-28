$(document).ready(function () {
    $(document)
        .on("click", "#register_user_button", submitRegisterUserForm);
});

function submitRegisterUserForm(e){
    e.preventDefault();

    let register_user_form = $("#register_user_form");

    $.post(register_user_form.attr("action"), register_user_form.serialize(), function(register_user_response){
        if(register_user_response.status){
            window.open("/accounts/home_page", "_self");
        }
        else{
            /* alert for faster error handling
                TODO: cleanup
            */
            let {email, password, name} = register_user_response.result;

            if(email){
                alert(email);
            }
            if(name){
                alert(name);
            }
            if(password){
                alert(password);
            }
        }
    })
}

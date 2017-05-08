$(function() {
  $("#register_new_user").validate();
  // $("#new_user").validate({
  //   submitHandler: function(form) {
  //     form.submit();
  //   }
  // });
  $('#user_email').rules('add', {
    required: true,
    email: true,
    remote: {
      url: '/users/validation_email',
      type: 'get',
      complete: function(data) {
        if (data.responseJSON) {
          $('.user_email').removeClass('pseudo-fade-in-invalid');
          $('.user_email').addClass('pseudo-fade-in-valid');
        } else {
          $('.user_email').removeClass('pseudo-fade-in-valid');
          $('.user_email').addClass('pseudo-fade-in-invalid');
        }
      }
    },
    messages: {
      required: "Please enter email",
      email: "Email not valid",
      remote: "Someone already has that email. Try another?"
    }
  });

  $('#user_password').rules('add', {
    required: true,
    minlength: 6,
    messages: {
      required: "Please enter password",
      minlength: "Password must be at least 6 characters"
    }
  });

  $('#user_password_confirmation').rules('add', {
    required: true,
    minlength: 6,
    equalTo: "#user_password",
    messages: {
      required: "Please confirm password",
      minlength: "Cofirm password must be at least 6 characters",
      equalTo: "Please enter the same password as above"
    }
  });
});
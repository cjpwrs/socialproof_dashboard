$(function() {
  Stripe.setPublishableKey("pk_test_OfdmQReUz0BqhqUjAuMK4x7F");
  stripe_initialize();
});

var stripe_initialize = function() {
  var $form = $('#new_subscription');
  $form.submit(function(event) {
    Stripe.card.createToken({
      number: $('#subscription_card_number').val(),
      cvc: $('#subscription_card_cvc').val(),
      exp: $('#subscription_card_expiry').val()
    }, stripeResponseHandler);
  });
};

function stripeResponseHandler(status, response) {
  console.log(status);
  if (status === 200) {
    return alert(response.id);
  } else {
    return alert(response.error.message);
  }
};

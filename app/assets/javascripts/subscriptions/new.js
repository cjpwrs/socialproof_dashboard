$(function() {
  Stripe.setPublishableKey("pk_test_OfdmQReUz0BqhqUjAuMK4x7F");
  stripe_initialize();
});

var stripe_initialize = function() {
  var $form = $('#new_subscription');
  $form.submit(function(event) {
    $('input[type=submit]').attr('disabled', true)
    Stripe.card.createToken({
      number: $('#subscription_card_number').val(),
      cvc: $('#subscription_card_cvc').val(),
      exp: $('#subscription_card_expiry').val()
    }, stripeResponseHandler);
    return false;
  });
};

function stripeResponseHandler(status, response) {
  var $form = $('#new_subscription');
  if (status === 200) {
    var token = response.id;
    $('#subscription_stripe_card_token').val(response.id);
    $form.get(0).submit();
  } else {
    $('input[type=submit]').attr('disabled', false)
    return alert(response.error.message);
  }
};

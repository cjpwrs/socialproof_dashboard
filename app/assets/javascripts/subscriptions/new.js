$(function() {
  Stripe.setPublishableKey( $('meta[name="stripe-key"]').attr('content') );
  stripe_initialize();
})

var stripe_initialize = function() {
  var $form = $('#new_subscription');
    $form.submit(function(event) {
      if($('#user_accepted_terms').is(":checked") === true){
        $('input[type=submit]').attr('disabled', true)
        Stripe.card.createToken({
          number: $('#subscription_card_number').val(),
          cvc: $('#subscription_card_cvc').val(),
          exp: $('#subscription_card_expiry').val()
        }, stripeResponseHandler);
        return false;
      }
      else {
        Stripe.card.createToken({
          number: "",
          cvc: "",
          exp: ""
        }, stripeResponseHandler);
        return false;
      }
    })
  }

function stripeResponseHandler(status, response) {
  var $form = $('#new_subscription');
  if (status === 200) {
    var token = response.id;
    $('#subscription_stripe_card_token').val(response.id);
    $form.get(0).submit();
  } else {
    window.location.replace("/subscriptions/new");
    return alert("One or more fields is not filled out or wrong.");
  }
};

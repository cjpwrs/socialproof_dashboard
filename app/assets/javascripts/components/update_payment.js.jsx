var UpdatePayment = React.createClass({
  getInitialState: function() {
    return {
      currentSubscription: {},
      cardNumber: '',
      cardExpiry: '',
      cardCvc: '',
      error: ''
    };
  },
  updatePayment: function() {
    var self = this;
    $.ajax({
      url: '/subscriptions/update_authorize_subscription',
      type: 'POST',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token"),
        card_number: this.state.cardNumber,
        card_expiry: this.state.cardExpiry,
        card_cvc: this.state.cardCvc
      },
      success: function(data) {
        window.location.href = data.redirect_url;
      },
      error: function(xhr, status) {
        const { responseJSON: { error } } = xhr;
        self.setState({ error });
      }
    });
  },
  onChange: function(e) {
    this.setState({
      [e.target.name]: e.target.value,
      error: ''
    });
  },
  validateInputs: function() {
    const { cardNumber, cardExpiry, cardCvc } = this.state;
    return cardNumber && cardExpiry && cardCvc;
  },
  render() {
    return (
      <div className="update-payment-container">
        <h4>Credit Card Number</h4>
        <div>
          <input
            className="payment-input card-number"
            type='text'
            name='cardNumber'
            placeholder='Card Number'
            onChange={this.onChange}
          />
        </div>
        <h4>Card Expiration</h4>
        <div>
          <input
            className="payment-input card-expiry"
            type='text'
            name='cardExpiry'
            placeholder='i.e. 12/18'
            onChange={this.onChange}
          />
        </div>
        <h4>CVC</h4>
        <div>
          <input
            className="payment-input card-cvc"
            type='text'
            name='cardCvc'
            placeholder='CVC'
            onChange={this.onChange}
          />
        </div>
        {this.state.error && <div className="payment-error">{this.state.error}</div>}
        {this.validateInputs()
          ? <button onClick={this.updatePayment} className="update-payment-button">Update Card</button>
          : <button className="update-payment-button payment-button-disabled">Update Card</button>
        }
      </div>
    )
  }
});

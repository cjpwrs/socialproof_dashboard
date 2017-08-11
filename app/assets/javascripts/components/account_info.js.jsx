var AccountInfo = React.createClass({
  getInitialState: function() {
    return {
      accountInfo: [],
      getInfo: false
    };
  },
  componentDidMount: function() {
    this.getDataFromApi();
  },
  getDataFromApi: function() {
    var self = this;
    $.ajax({
      url: 'users/account_info',
      type: 'GET',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token")
      },
      success: function(data) {
        if(data) {
          stripe_subscription = data.response.stripe_subscription
          stim_response = JSON.parse(data.response.stim_response);
          let instagram_redirect = null;
          if(stim_response.success){
            instagram_redirect = "https://www.instagram.com/" + stim_response.data.Username;
            $('.instagram-username').text(stim_response.data.Username);
          }
          if(stripe_subscription) {
            $('.account-status').text(stripe_subscription.status);
            $('.account-plan').text(stripe_subscription.plan.name);
          }

          self.setState({
            accountInfo: stim_response,
            getInfo: stim_response.success,
            instagram_redirect: instagram_redirect
          });
        } else {
          $('.account-status').text('inactive');
          $('.account-plan').text('no active plan');
        }
      },
      error: function(xhr, status, error) {
        alert('Cannot get data from API: ', error);
      }
    });
  },
  render() {
    if (this.state.getInfo == true ){
      var image_url = this.state.accountInfo.data.MetaData.info.profile_pic_url
    }else{
      var image_url = 'https://cdn.dribbble.com/users/172906/screenshots/1185018/2013-08-04_21_14_41.gif'
    }

    let accountButton = null;
    if(this.state.instagram_redirect) {
      accountButton = (
        <a href={this.state.instagram_redirect} target="_blank">
          <button className="account-button">Account Profile</button>
        </a>
      )
    }
    return (
      <div className="account-info-container">
        <img alt="..." className="media-object img-circle" src={image_url} />
        {accountButton}
      </div>
    )
  }
});

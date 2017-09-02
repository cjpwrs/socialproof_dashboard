var TargetAccounts = React.createClass({
  getInitialState: function() {
    return {
      targetAccounts: [],
      newTargetAccount: ''
    };
  },
  componentDidMount: function() {
    this.getDataFromApi();
  },
  getDataFromApi: function() {
    var self = this;
    $.ajax({
      url: 'users/target_accounts',
      type: 'GET',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token")
      },
      success: function(data) {
        if(data.response){
          self.setState({ targetAccounts: data.response });
        }
      },
      error: function(xhr, status, error) {
        console.log(error);
      }
    });
  },
  addTargetAccount: function() {
    if(this.state.newTargetAccount.length > 0) {
      var self = this;
      $.ajax({
        url: 'users/add_target_account',
        type: 'POST',
        data: {
          authenticity_token: Functions.getMetaContent("csrf-token"),
          new_target_account: this.state.newTargetAccount
        },
        success: function(data) {
          if(data.response){
            self.setState({
              targetAccounts: data.response,
              newTargetAccount: ''
            });
          }
        },
        error: function(xhr, status, error) {
          console.log(error);
        }
      });
    }
  },
  deleteTargetAccount: function(target_account_id) {
    var self = this;
    $.ajax({
      url: 'users/delete_target_account',
      type: 'POST',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token"),
        target_account_id: target_account_id
      },
      success: function(data) {
        if(data.response){
          self.setState({ targetAccounts: data.response });
        }
      },
      error: function(xhr, status, error) {
        console.log(error);
      }
    });
  },
  handleOnChange: function(e) {
    var self = this;
    self.setState({
      [e.target.name]: e.target.value
    })

  },
  handleInputKeyDown: function(event) {
    var self = this;
    if (event.keyCode === 13 && !event.shiftKey) {
      event.preventDefault();
      this.addTargetAccount();
    }
  },
  render() {
    var targetAccounts = this.state.targetAccounts;
    var targetAccountComponents = [];
    if(targetAccounts.length > 0) {
      for(i = 0; i < targetAccounts.length; i++) {
        targetAccountComponents.push(
          <div className="target-account-container" key={targetAccounts[i].id}>
            {targetAccounts[i].instagram_handle}
            <div
              className="target-account-close-button"
              onClick={this.deleteTargetAccount.bind(null, targetAccounts[i].id)}
            >
              <img
                className='target-account-close-image'
                src="http://cdn.shopify.com/s/files/1/1164/4258/t/1/assets/close-large-white.png?4307655770055302400" alt="close"
              />
            </div>
          </div>
        );
      }
    }
    return (
      <div className="target-accounts-component">
        <div className="target-accounts-column">
          <h2>You target, we find</h2>
          <div className="target-accounts-explanation">
            <p>You target followers by picking other instagram accounts similar to yours.</p>
            <p className="pro-tip">We will find new followers for you by liking posts and following/unfollowing people who interact with these accounts. We will unfollow everyone that we follow for you.</p>
            <p className="pro-tip"><span className="pro-tip-bold">PRO TIP</span>: Add 15(max) accounts that have followers between 10,000 and 80,000</p>
          </div>
          <div className="new-target-account-form">
            <input
              className="new-target-account"
              name="newTargetAccount"
              onChange={this.handleOnChange}
              onKeyDown={this.handleInputKeyDown}
              value={this.state.newTargetAccount}
              placeholder="Instagram Username"
            />
            <button
              className="new-target-account-button"
              onClick={this.addTargetAccount}>
                Add
            </button>
          </div>
        </div>
        <div className="target-accounts-column target-account-holder">
          {targetAccountComponents}
        </div>
      </div>
    )
  }
});

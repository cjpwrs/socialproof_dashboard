var UpgradeAccount = React.createClass({
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
      url: 'subscriptions/upgrade_plan',
      type: 'GET',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token")
      },
      success: function(data) {
        // console.log(data);
        // if(data.response){
        //   self.setState({ targetAccounts: data.response });
        // }
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
    // var targetAccounts = this.state.targetAccounts;
    // var targetAccountComponents = [];
    // if(targetAccounts.length > 0) {
    //   for(i = 0; i < targetAccounts.length; i++) {
    //     targetAccountComponents.push(
    //       <div className="target-account-container" key={targetAccounts[i].id}>
    //         {targetAccounts[i].instagram_handle}
    //         <div
    //           className="target-account-close-button"
    //           onClick={this.deleteTargetAccount.bind(null, targetAccounts[i].id)}
    //         >
    //           <img
    //             className='target-account-close-image'
    //             src="http://cdn.shopify.com/s/files/1/1164/4258/t/1/assets/close-large-white.png?4307655770055302400" alt="close"
    //           />
    //         </div>
    //       </div>
    //     );
    //   }
    // }
    return (
      <div className="target-accounts-component">
        hello
      </div>
    )
  }
});

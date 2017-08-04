var TargetAccounts = React.createClass({
  getInitialState: function() {
    return {
      targetAccounts: [],
      newTargetAccount: 'cjpwrs'
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
        console.log(data);
        if(data.response){
          console.log('hello')
          self.setState({ targetAccounts: data.response });
        }
      },
      error: function(xhr, status, error) {
        alert('Cannot get data from API: ', error);
      }
    });
  },
  addTargetAccount: function() {
    var self = this;
    $.ajax({
      url: 'users/add_target_account',
      type: 'POST',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token"),
        new_target_account: this.state.newTargetAccount
      },
      success: function(data) {
        console.log(data);
        if(data.response){
          console.log('hello')
          self.setState({ targetAccounts: data.response });
        }
      },
      error: function(xhr, status, error) {
        alert('Cannot get data from API: ', error);
      }
    });
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
        console.log(data);
        if(data.response){
          console.log('hello')
          self.setState({ targetAccounts: data.response });
        }
      },
      error: function(xhr, status, error) {
        alert('Cannot get data from API: ', error);
      }
    });
  },
  render() {
    console.log('hello')
    var targetAccounts = this.state.targetAccounts;
    var targetAccountComponents = [];
    if(targetAccounts.length > 0) {
      console.log('entered if');
      for(i = 0; i < targetAccounts.length; i++) {
        console.log(targetAccounts[i]);
        targetAccountComponents.push(
          <div key={i}>
            {targetAccounts[i].instagram_handle}
          </div>
        );
      }
    }
    return (
      <div>
        <button onClick={this.addTargetAccount}>add</button>
        {targetAccountComponents}
        <div>{this.state.target_accounts && this.state.target_accounts[0].instagram_handle}</div>
      </div>
    )
  }
});

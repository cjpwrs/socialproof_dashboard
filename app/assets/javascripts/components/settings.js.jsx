var Settings = React.createClass({
  getInitialState: function() {
    return {
      targetAccounts: [],
      newTargetAccount: '',
      maxFollowing: ''
    };
  },
  componentDidMount: function() {
    this.getDataFromApi();
  },
  getDataFromApi: function() {
    var self = this;
    $.ajax({
      url: 'users/max_following',
      type: 'GET',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token")
      },
      success: function(data) {
        if(data.response){
          self.setState({ maxFollowing: data.response });
        }
      },
      error: function(xhr, status, error) {
        console.log(error);
      }
    });
  },
  setMaxFollowing: function(maxFollowing) {
    if(this.state.maxFollowing !== maxFollowing) {
      var self = this;
      $.ajax({
        url: 'users/set_max_following',
        type: 'POST',
        data: {
          authenticity_token: Functions.getMetaContent("csrf-token"),
          max_following: maxFollowing
        },
        success: function(data) {
          if(data.response){}
        },
        error: function(xhr, status, error) {
          console.log(error);
        }
      });
    }
  },
  handleOnChange: function(e) {
    var self = this;
    var maxFollowing = e.target.value;
    self.setMaxFollowing(maxFollowing);
    self.setState({
      maxFollowing: maxFollowing
    })
  },
  render() {
    var maxFollowing = this.state.maxFollowing;
    var maxFollowingOptions = [7000, 6000, 5000, 4000, 3000, 2000];
    var maxFollowingSelect = [];
    for(i = 0; i < maxFollowingOptions.length; i++) {
      maxFollowingSelect.push(
        <option
          value={maxFollowingOptions[i]}
          key={i}
        >
          {maxFollowingOptions[i]}
        </option>
      );
    }
    return (
      <div className="target-accounts-component">
        <div className="target-accounts-column">
          <h2>Max Following</h2>
          <div className="target-accounts-explanation">
            <p>Set the maximum number of accounts to follow up to before SocialProof automatically switches to unfollow mode.</p>
          </div>
          <select className="max-following-select" value={maxFollowing} onChange={this.handleOnChange}>
            {maxFollowingSelect}
          </select>
        </div>
      </div>
    )
  }
});

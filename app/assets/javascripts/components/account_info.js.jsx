var AccountInfo = React.createClass({
  getInitialState: function() {
    return { 
      accountInfo: []
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
        json_data = JSON.parse(data.response)
        $('.instagram-username').text(json_data.data.Username);
        self.setState({ accountInfo: JSON.parse(data.response) });
      },
      error: function(xhr, status, error) {
        alert('Cannot get data from API: ', error);
      }
    });
  },
  render() {
    if (this.state.accountInfo.data != null){
      var image_url = this.state.accountInfo.data.MetaData.info.profile_pic_url
    }else{
      var image_url = 'https://cdn.dribbble.com/users/172906/screenshots/1185018/2013-08-04_21_14_41.gif'
    }
    return (
      <a href="#">
        <img alt="..." className="media-object img-circle" src={image_url} />
      </a>
    )
  }
});

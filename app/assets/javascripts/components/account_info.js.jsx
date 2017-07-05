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
        self.setState({ accountInfo: JSON.parse(data.response) });
      },
      error: function(xhr, status, error) {
        alert('Cannot get data from API: ', error);
      }
    });
  },
  render() {
    debugger
    if (this.state.accountInfo.data != null){
      var image_url = this.state.accountInfo.data.MetaData.info.profile_pic_url
    }else{
      var image_url = 'http://www.zachalbert.com/images/ruf-s2.png'
    }
    return (
      <a href="#">
        <img alt="..." className="media-object img-circle" src={image_url} />
      </a>
    )
  }
});

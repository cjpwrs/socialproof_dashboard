var TopEngagers = React.createClass({
  getInitialState: function() {
    return { 
      topEngagersInfo: [],
      getTopEngagers: false
    };
  },
  componentDidMount: function() {
    this.getDataFromApi();
  },
  getDataFromApi: function() {
    var self = this;
    $.ajax({
      url: 'users/top_engagers',
      type: 'GET',
      data: { 
        authenticity_token: Functions.getMetaContent("csrf-token")
      },
      success: function(data) {
        json_data = JSON.parse(data.response);
        console.log(json_data);
        console.log('Call api successfull');
      },
      error: function(xhr, status, error) {
        alert('Cannot get data from API: ', error);
      }
    });
  },
  render() {
    return (
    )
  }
});

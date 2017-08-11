var TargetPerformance = React.createClass({
  getInitialState: function() {
    return {
      topEngagers: [],
      getEngagers: false
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
        self.setState({
          topEngagers: json_data.data,
          getEngagers: true
        })
      },
      error: function(xhr, status, error) {
        alert('Cannot get data from API: ', error);
      }
    });
  },
  render() {
    var topEngagers = this.state.topEngagers;
    var engagerComponents = [];
    if(topEngagers.length > 0) {
      for(i = 0; i < topEngagers.length; i++) {
        engagerComponents.push(
          <tr key={topEngagers[i].username}>
            <th scope="row"><img alt="..." className="img-circle" src={topEngagers[i].profile_image} />&nbsp;<span>{topEngagers[i].username}</span></th>
            <td className="text-right"><i aria-hidden="true" className="fa fa-heart circle-heart" /></td>
            <td className="text-center">{topEngagers[i].likes}</td>
            <td className="text-right"><i aria-hidden="true" className="fa fa-comment circle-comment" /></td>
            <td className="text-center">{topEngagers[i].comments}</td>
            <td className="text-center"><i aria-hidden="true" className="fa fa-check circle-check" /></td>
            <td />
          </tr>
        );
      }
    }
    return (
      <table className="table table-striped users-table">
        <tbody>
          <tr>
            <th colSpan={6} scope="row">Top Engagers</th>
            <td className="text-right"><small>Last 30 days</small></td>
          </tr>
          <tr>
            <th scope="row" />
            <td />
            <td className="text-center"><strong>Likes</strong></td>
            <td />
            <td className="text-center"><strong>Comments</strong></td>
            <td className="text-center"><strong>Whitelist</strong></td>
            <td />
          </tr>
          {engagerComponents}
        </tbody>
      </table>
    )
  }
});

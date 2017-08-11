var TopEngagers = React.createClass({
  getInitialState: function() {
    return {
      topEngagers: [],
      getEngagers: false,
      isLoading: false
    };
  },
  componentDidMount: function() {
    this.getDataFromApi();
  },
  getDataFromApi: function() {
    var self = this;
    self.setState({isLoading: true})
    $.ajax({
      url: 'users/top_engagers',
      type: 'GET',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token")
      },
      success: function(data) {
        json_data = JSON.parse(data.response);
        self.setState({
          topEngagers: json_data.data,
          getEngagers: true,
          isLoading: false
        })
      },
      error: function(xhr, status, error) {
        console.log('Cannot get data from API: ', error);
      }
    });
  },
  render() {
    var topEngagers = this.state.topEngagers;
    var engagerComponents = [];
    if(topEngagers.length > 0) {
      for(i = 0; i < topEngagers.length; i++) {
        engagerComponents.push(
          <tr className="engager-row" key={topEngagers[i].username}>
            <th className="engager-username">
              <img alt="..." className="img-circle" src={topEngagers[i].profile_image} />&nbsp;
              <a className="engager-url" target="_blank" href={topEngagers[i].url_profile}>{topEngagers[i].username}</a>
            </th>
            <td />
            <td className="text-center">
              <i aria-hidden="true" className="fa fa-heart circle-heart engager-icon" />
              <div className="engager-stat">{topEngagers[i].likes}</div>
            </td>
            <td className="text-center">
              <i aria-hidden="true" className="fa fa-comment circle-comment engager-icon" />
              <div className="engager-stat">{topEngagers[i].comments}</div>
            </td>
          </tr>
        );
      }
    }
    return (
      <div className="engager-container">
        <table className="table table-striped users-table">
          <tbody>
            <tr>
              <th colSpan={3} scope="row">Top Engagers</th>
              <td className="text-right"><small>Last 30 days</small></td>
            </tr>
            <tr>
              <th scope="row" />
              <td />
              <td className="text-center"><strong>Likes</strong></td>
              <td className="text-center"><strong>Comments</strong></td>
            </tr>
            {engagerComponents}
          </tbody>
        </table>
        {this.state.isLoading && <img src="https://d13yacurqjgara.cloudfront.net/users/12755/screenshots/1037374/hex-loader2.gif" alt="loading" />}
      </div>
    )
  }
});

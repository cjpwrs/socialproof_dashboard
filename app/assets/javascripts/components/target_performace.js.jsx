var TargetPerformance = React.createClass({
  getInitialState: function() {
    return { 
      targetInfo: [],
      getTarget: false
    };
  },
  componentDidMount: function() {
    this.getDataFromApi();
  },
  getDataFromApi: function() {
    var self = this;
    $.ajax({
      url: 'users/target_performance',
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
      <table className="table table-striped users-table">
        <tbody>
          <tr>
            <th colSpan={6} scope="row">Targeting Performance</th>
            <td className="text-right"><small>Last 30 days</small></td>
          </tr>
          <tr>
            <th scope="row" />
            <td />
            <td className="text-center"><strong>Comment</strong></td>
            <td />
            <td className="text-center"><strong>Comment</strong></td>
            <td className="text-center"><strong>Whitelist</strong></td>
            <td />
          </tr>
          <tr>
            <th scope="row"><img alt="..." className="img-circle" src="http://www.zachalbert.com/images/ruf-s2.png" />&nbsp;<span>Instagram user</span></th>
            <td className="text-right"><i aria-hidden="true" className="fa fa-heart circle-heart" /></td>
            <td className="text-center">100</td>
            <td className="text-right"><i aria-hidden="true" className="fa fa-comment circle-comment" /></td>
            <td className="text-center">200</td>
            <td className="text-center"><i aria-hidden="true" className="fa fa-check circle-check" /></td>
            <td />
          </tr>
          <tr>
            <th scope="row"><img alt="..." className="img-circle" src="http://www.zachalbert.com/images/ruf-s2.png" />&nbsp;<span>Instagram user</span></th>
            <td className="text-right"><i aria-hidden="true" className="fa fa-heart circle-heart" /></td>
            <td className="text-center">100</td>
            <td className="text-right"><i aria-hidden="true" className="fa fa-comment circle-comment" /></td>
            <td className="text-center">200</td>
            <td className="text-center"><i aria-hidden="true" className="fa fa-check circle-check" /></td>
            <td />
          </tr>
          <tr>
            <th scope="row"><img alt="..." className="img-circle" src="http://www.zachalbert.com/images/ruf-s2.png" />&nbsp;<span>Instagram user</span></th>
            <td className="text-right"><i aria-hidden="true" className="fa fa-heart circle-heart" /></td>
            <td className="text-center">100</td>
            <td className="text-right"><i aria-hidden="true" className="fa fa-comment circle-comment" /></td>
            <td className="text-center">200</td>
            <td className="text-center"><i aria-hidden="true" className="fa fa-check circle-check" /></td>
            <td />
          </tr>
          <tr>
            <th scope="row"><img alt="..." className="img-circle" src="http://www.zachalbert.com/images/ruf-s2.png" />&nbsp;<span>Instagram user</span></th>
            <td className="text-right"><i aria-hidden="true" className="fa fa-heart circle-heart" /></td>
            <td className="text-center">100</td>
            <td className="text-right"><i aria-hidden="true" className="fa fa-comment circle-comment" /></td>
            <td className="text-center">200</td>
            <td className="text-center"><i aria-hidden="true" className="fa fa-check circle-check" /></td>
            <td />
          </tr>
          <tr>
            <th scope="row"><img alt="..." className="img-circle" src="http://www.zachalbert.com/images/ruf-s2.png" />&nbsp;<span>Instagram user</span></th>
            <td className="text-right"><i aria-hidden="true" className="fa fa-heart circle-heart" /></td>
            <td className="text-center">100</td>
            <td className="text-right"><i aria-hidden="true" className="fa fa-comment circle-comment" /></td>
            <td className="text-center">200</td>
            <td className="text-center"><i aria-hidden="true" className="fa fa-check circle-check" /></td>
            <td />
          </tr>
          <tr>
            <th scope="row"><img alt="..." className="img-circle" src="http://www.zachalbert.com/images/ruf-s2.png" />&nbsp;<span>Instagram user</span></th>
            <td className="text-right"><i aria-hidden="true" className="fa fa-heart circle-heart" /></td>
            <td className="text-center">100</td>
            <td className="text-right"><i aria-hidden="true" className="fa fa-comment circle-comment" /></td>
            <td className="text-center">200</td>
            <td className="text-center"><i aria-hidden="true" className="fa fa-check circle-check" /></td>
            <td />
          </tr>
        </tbody>
      </table>
    )
  }
});

var UpgradeAccount = React.createClass({
  getInitialState: function() {
    return {
      plans: [],
      currentSubscription: {},
      selectedPlan: '',
      proration: '',
      selectedPlanData: {},
      selectedPlanPrice: ''
    };
  },
  componentDidMount: function() {
    this.getDataFromApi();
  },
  getDataFromApi: function() {
    var self = this;
    $.ajax({
      url: '/subscriptions/get_upgrade_plan',
      type: 'GET',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token")
      },
      success: function(data) {
        console.log(data);
        if(data.response){
          self.setState({
            plans: data.response.plans,
            currentSubscription: data.response.current_subscription
          });
        }
      },
      error: function(xhr, status, error) {
        console.log(error);
      }
    });
  },
  getProration: function(plan) {
    var self = this;
    $.ajax({
      url: '/subscriptions/get_proration',
      type: 'POST',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token"),
        selected_plan: plan
      },
      success: function(data) {
        console.log(data);
        if(data.response){
          self.setState({
            proration: data.response.proration,
            selectedPlanData: data.response.selected_plan,
            selectedPlanPrice: data.response.selected_plan_price
          });
        }
      },
      error: function(xhr, status, error) {
        console.log(error);
      }
    });
  },
  upgradePlan: function() {
    var self = this;
    $.ajax({
      url: '/subscriptions/upgrade_plan',
      type: 'POST',
      data: {
        authenticity_token: Functions.getMetaContent("csrf-token"),
        selected_plan: this.state.selectedPlan
      },
      success: function(data) {
        console.log(data);
        if(data.response){
          self.setState({
            proration: data.response.proration,
            selectedPlanData: data.response.selected_plan,
            selectedPlanPrice: data.response.selected_plan_price
          });
        }
      },
      error: function(xhr, status, error) {
        console.log(error);
      }
    });
  },
  handleOnChange: function(e) {
    var self = this;
    console.log(e.target.value);
    self.setState({
      selectedPlan: e.target.value
    })
    this.getProration(e.target.value)
  },
  handleInputKeyDown: function(event) {
    var self = this;
    if (event.keyCode === 13 && !event.shiftKey) {
      event.preventDefault();
      this.addTargetAccount();
    }
  },
  render() {
    console.log(this.state.selectedPlan);
    var plans = this.state.plans;
    var planComponents = [];
    if(plans.length > 0) {
      for(i = 0; i < plans.length; i++) {
        planComponents.push(
          <option id={plans[i][1]} key={plans[i][1]}>
            {plans[i][0]}
          </option>
        );
      }
    }
    return (
      <div className="upgrade-account-container">
        <select
          onChange={this.handleOnChange}
          value={this.state.selectedPlan}
          placeholder="Select a plan"
          className="new-plan-selector">
          <option disabled defaultValue> -- Select a plan -- </option>
          {planComponents}
        </select>
        {this.state.proration && <div className="proration-preview">
          <h4>Preview of how your next payment will look</h4>
          <div className="prorated-item">
            <div className="prorated-item-desc">Prorated price of upgrading to the {this.state.selectedPlanData.name} plan for the remainder of your current billing cycle</div>
            <div className="prorated-item-amount">${Math.round(this.state.proration * 100) / 100}</div>
          </div>
          <div className="prorated-item">
            <div className="prorated-item-desc">The normal monthly price of the {this.state.selectedPlanData.name} plan</div>
            <div className="prorated-item-amount prorated-last-item">+ ${Math.round(this.state.selectedPlanPrice * 100) / 100}</div>
          </div>
          <div className="prorated-item">
            <div className="prorated-item-desc">Estimated total of next payment</div>
            <div className="prorated-item-amount">${Math.round((this.state.selectedPlanPrice + this.state.proration) * 100) / 100}</div>
          </div>
        </div>}
        {this.state.proration && <button onClick={this.upgradePlan} className="upgrade-plan-button">
          Upgrade Plan
        </button>}
      </div>
    )
  }
});

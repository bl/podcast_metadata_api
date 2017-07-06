class Login extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      username: '',
      password: '',
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    const name = event.target.name;
    const value = event.target.value;
    this.setState({
      [name]: value,
    });
  }

  handleSubmit(event) {
  }

  render() {
    return (
      <form
        className="login"
        onSubmit={this.handleSubmit}>
        <input
          name='username'
          placeholder='Username'
          type='text'
          value={this.state.username}
          autoComplete='off'
          onChange={this.handleChange}
        />
        <input
          name='password'
          placeholder='Password'
          type='password'
          value={this.state.password}
          autoComplete='off'
          onChange={this.handleChange}
        />
        <button
          type='submit'
          disabled={!this.state.username || !this.state.password}>
          Submit
        </button>
      </form>
    );
  }
}

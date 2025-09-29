const API_BASE = process.env.REACT_APP_API_BASE_URL || '';

async function request(path, options) {
  const resp = await fetch(`${API_BASE}${path}`, {
    headers: { 'Content-Type': 'application/json', ...(options?.headers || {}) },
    ...options
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok) {
    const message = data?.Error || data?.message || 'Request failed';
    throw new Error(message);
  }
  return data?.Data || data; // backend sometimes wraps in { Data, Code, Message }
}

export async function login({ identifier, password }) {
  const payload = { Identifier: identifier, Password: password };
  const data = await request('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify(payload)
  });
  return {
    accessToken: data.AccessToken || data.accessToken,
    refreshToken: data.RefreshToken || data.refreshToken,
    user: data.User || data.user
  };
}

export async function register({ email, username, password, fullname, mssv }) {
  const payload = {
    Email: email,
    Username: username,
    Password: password,
    Fullname: fullname,
    MSSV: mssv
  };
  const data = await request('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify(payload)
  });
  return {
    accessToken: data.AccessToken || data.accessToken,
    refreshToken: data.RefreshToken || data.refreshToken,
    user: data.User || data.user
  };
}

export default { login, register };



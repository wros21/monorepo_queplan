export const environment = {
  production: true,
  apiUrl: window.location.hostname.includes("localhost")
    ? "http://localhost:3000/api"
    : `https://${window.location.hostname.replace("frontend", "backend")}/api`,
}

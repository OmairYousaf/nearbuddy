function getCurrentPosition() {
  return new Promise((resolve, reject) => {
  if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
      (position) => {
    resolve(position.coords);
  },
  (error) => {
  reject(error.message);
  }
  );
  } else {
  reject("Geolocation is not available in this browser.");
  }
});
}

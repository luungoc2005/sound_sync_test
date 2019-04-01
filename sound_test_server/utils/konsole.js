export const noop = () => null;

export const konsole = {
  log: (process.NODE_ENV === 'production' ? noop : console.log),
  error: (process.NODE_ENV === 'production' ? noop : console.error)
}

export default konsole;
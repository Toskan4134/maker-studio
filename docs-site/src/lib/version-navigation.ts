export async function navigateToVersion(select: HTMLSelectElement): Promise<void> {
  const path = select.value;
  const home = path.replace(/\/(?:guides|mods)\/[^/]+\/?$/, "/");
  let destination = path;
  if (home !== path) {
    const response = await fetch(path, { method: "HEAD" }).catch(() => null);
    if (response?.status === 404) destination = home;
  }
  if (select.value === path) window.location.pathname = destination;
}

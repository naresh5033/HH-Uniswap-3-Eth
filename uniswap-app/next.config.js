/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  swcMinify: true,
  eslint: { ignoreDuringBuilds: true },
  distDir: "build",
};

module.exports = nextConfig;

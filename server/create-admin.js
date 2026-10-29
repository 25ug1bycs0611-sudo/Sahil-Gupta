import "dotenv/config";
import bcrypt from "bcryptjs";
import pg from "pg";

const { DATABASE_URL, JWT_SECRET, ADMIN_NAME, ADMIN_EMAIL, ADMIN_PASSWORD } = process.env;
if (!DATABASE_URL || !JWT_SECRET || !ADMIN_NAME || !ADMIN_EMAIL || !ADMIN_PASSWORD) {
  console.error("Set DATABASE_URL, JWT_SECRET, ADMIN_NAME, ADMIN_EMAIL, and ADMIN_PASSWORD in .env before creating an administrator.");
  process.exitCode = 1;
} else if (JWT_SECRET.length < 32 || /^replace/i.test(JWT_SECRET) || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(ADMIN_EMAIL) || ADMIN_PASSWORD.length < 12 || ADMIN_PASSWORD.length > 128 || /^replace/i.test(ADMIN_PASSWORD)) {
  console.error("Use a unique JWT_SECRET of at least 32 characters, a valid administrator email, and a unique password between 12 and 128 characters.");
  process.exitCode = 1;
} else {
  const pool = new pg.Pool({ connectionString: DATABASE_URL, ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: true } : undefined });
  try {
    const passwordHash = await bcrypt.hash(ADMIN_PASSWORD, 12);
    await pool.query(
      "INSERT INTO users (name, email, password_hash, role) VALUES ($1, lower($2), $3, 'admin')",
      [ADMIN_NAME.trim(), ADMIN_EMAIL.trim(), passwordHash],
    );
    console.log("Administrator account created.");
  } catch (error) {
    if (error.code === "23505") {
      console.error("An account already uses that email. No administrator was created.");
    } else {
      console.error("Administrator creation failed:", error.message);
    }
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

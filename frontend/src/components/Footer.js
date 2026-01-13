import { Link } from "react-router-dom";

const Footer = ({ translations, language }) => {
  return (
    <footer>
      <Link to="/about">{translations[language].about}</Link>
    </footer>
  );
};

export default Footer;
